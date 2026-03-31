//
//  Condition.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct Condition: Codable, Sendable {
    let text: String
    let code: Int
}
