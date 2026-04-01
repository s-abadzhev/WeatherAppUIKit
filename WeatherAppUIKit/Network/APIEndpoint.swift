//
//  APIEndpoint.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

enum APIEndpoint: Sendable {
    case currentWeather(lat: Double, lon: Double)
    case forecast(lat: Double, lon: Double)

    var path: String {
        switch self {
        case .currentWeather:
            return "/current.json"
        case .forecast:
            return "/forecast.json"
        }
    }

    private var baseURL: String {
        return "https://api.weatherapi.com/v1"
    }

    private var apiKey: String {
        return "fa8b3df74d4042b9aa7135114252304"
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .currentWeather(let lat, let lon):
            return [
                .init(name: "key", value: apiKey),
                .init(name: "q", value: "\(lat),\(lon)")
            ]
        case .forecast(let lat, let lon):
            return [
                .init(name: "key", value: apiKey),
                .init(name: "q", value: "\(lat),\(lon)"),
                .init(name: "days", value: "3")
            ]
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
