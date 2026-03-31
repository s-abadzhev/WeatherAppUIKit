//
//  Location.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct Location: Codable, Sendable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}
