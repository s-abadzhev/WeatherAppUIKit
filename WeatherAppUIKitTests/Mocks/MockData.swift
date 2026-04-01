//
//  MockData.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation
import CoreLocation
@testable import WeatherAppUIKit

enum MockData {

    static let coordinate = CLLocationCoordinate2D(latitude: 55.75, longitude: 37.61)

    static let condition = Condition(text: "Sunny", code: 1000)

    static let currentWeather = CurrentWeather(
        tempC: 20.5,
        condition: condition,
        feelslikeC: 18.0,
        humidity: 60,
        windKph: 15.0
    )

    static let location = Location(
        name: "Moscow",
        region: "Moscow",
        country: "Russia",
        localtime: "2026-04-01 12:00"
    )

    static let currentResponse = CurrentResponse(location: location, current: currentWeather)

    static let day1 = Day(maxtempC: 25.0, mintempC: 10.0, condition: condition)
    static let day2 = Day(maxtempC: 22.0, mintempC:  8.0, condition: condition)
    static let day3 = Day(maxtempC: 18.0, mintempC: 12.0, condition: condition)

    static func hours(date: String) -> [HourWeather] {
        (0..<24).map { h in
            HourWeather(
                time: "\(date) \(String(format: "%02d", h)):00",
                tempC: Double(h),
                condition: condition
            )
        }
    }

    static let forecastResponse = ForecastResponse(
        location: location,
        current: currentWeather,
        forecast: Forecast(forecastday: [
            ForecastDay(date: "2026-04-01", day: day1, hour: hours(date: "2026-04-01")),
            ForecastDay(date: "2026-04-02", day: day2, hour: hours(date: "2026-04-02")),
            ForecastDay(date: "2026-04-03", day: day3, hour: hours(date: "2026-04-03"))
        ])
    )

    /// Minimal valid JSON matching `CurrentResponse` CodingKeys.
    static let currentResponseJSON: Data = """
    {
        "location": {
            "name": "Moscow", "region": "Moscow",
            "country": "Russia", "localtime": "2026-04-01 12:00"
        },
        "current": {
            "temp_c": 20.5,
            "condition": { "text": "Sunny", "code": 1000 },
            "feelslike_c": 18.0,
            "humidity": 60,
            "wind_kph": 15.0
        }
    }
    """.data(using: .utf8)!
}
