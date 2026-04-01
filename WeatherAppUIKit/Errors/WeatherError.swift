//
//  WeatherError.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation

enum WeatherError: LocalizedError {
    case timeout

    var errorDescription: String? { L10n.Error.timeout }
}
