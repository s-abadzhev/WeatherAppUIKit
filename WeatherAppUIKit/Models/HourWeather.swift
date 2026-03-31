//
//  HourWeather.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct HourWeather: Codable, Sendable {
    let time: String
    let tempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }
}
