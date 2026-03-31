//
//  Day.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct Day: Codable, Sendable {
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}
