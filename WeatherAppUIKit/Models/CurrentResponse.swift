//
//  CurrentResponse.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct CurrentResponse: Codable, Sendable {
    let location: Location
    let current: CurrentWeather
}
