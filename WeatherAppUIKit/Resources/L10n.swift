//
//  L10n.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

enum L10n {
    enum Common {
        static let retry = NSLocalizedString("common.retry", comment: "Retry button title")
    }

    enum Weather {
        static let hourlyForecast = NSLocalizedString("weather.hourlyForecast", comment: "Hourly forecast section title")
        static let dailyForecast  = NSLocalizedString("weather.dailyForecast",  comment: "Daily forecast section title")
        static let feelsLike      = NSLocalizedString("weather.feelsLike",      comment: "Feels like card title")
        static let humidity       = NSLocalizedString("weather.humidity",       comment: "Humidity card title")
        static let wind           = NSLocalizedString("weather.wind",           comment: "Wind card title")
        static let now            = NSLocalizedString("weather.now",            comment: "Current hour label in hourly forecast")

        static func hiLo(hi: Int, lo: Int) -> String {
            String(format: NSLocalizedString("weather.hiLo", comment: "High/low temperature"), hi, lo)
        }

        static func windSpeed(_ speed: Int) -> String {
            String(format: NSLocalizedString("weather.windSpeed", comment: "Wind speed with unit"), speed)
        }

        static func loadingError(_ message: String) -> String {
            String(format: NSLocalizedString("weather.loadingError", comment: "Weather loading error with reason"), message)
        }
    }

    enum Error {
        static let invalidURL = NSLocalizedString("error.invalidURL", comment: "Invalid URL error")
        static let noInternet = NSLocalizedString("error.noInternet", comment: "No internet error")
        static let timeout    = NSLocalizedString("error.timeout",    comment: "Timeout error")
        static let decoding   = NSLocalizedString("error.decoding",   comment: "Decoding error")

        static func server(_ code: Int) -> String {
            String(format: NSLocalizedString("error.server", comment: "Server error with status code"), code)
        }
    }
}
