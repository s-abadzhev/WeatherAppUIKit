//
//  CurrentWeather.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct CurrentWeather: Codable, Sendable {
    let tempC: Double
    let condition: Condition
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
        case feelslikeC = "feelslike_c"
        case humidity
        case windKph = "wind_kph"
    }
}
