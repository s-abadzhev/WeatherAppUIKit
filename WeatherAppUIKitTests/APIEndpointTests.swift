//
//  APIEndpointTests.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Testing
import Foundation
@testable import WeatherAppUIKit

@Suite("APIEndpoint")
struct APIEndpointTests {

    // MARK: - URL Validity

    @Test("currentWeather produces a non-nil URL")
    func currentWeatherURLNonNil() {
        #expect(APIEndpoint.currentWeather(lat: 55.75, lon: 37.61).url != nil)
    }

    @Test("forecast produces a non-nil URL")
    func forecastURLNonNil() {
        #expect(APIEndpoint.forecast(lat: 55.75, lon: 37.61).url != nil)
    }

    // MARK: - Paths

    @Test("currentWeather URL contains /current.json")
    func currentWeatherPath() {
        let url = APIEndpoint.currentWeather(lat: 55.75, lon: 37.61).url!
        #expect(url.absoluteString.contains("/current.json"))
    }

    @Test("forecast URL contains /forecast.json")
    func forecastPath() {
        let url = APIEndpoint.forecast(lat: 55.75, lon: 37.61).url!
        #expect(url.absoluteString.contains("/forecast.json"))
    }

    // MARK: - Query Parameters

    @Test("currentWeather encodes coordinates as 'q' parameter")
    func currentWeatherCoordinates() {
        let items = APIEndpoint.currentWeather(lat: 55.75, lon: 37.61).queryItems
        let q = items.first(where: { $0.name == "q" })
        #expect(q?.value == "55.75,37.61")
    }

    @Test("forecast encodes coordinates as 'q' parameter")
    func forecastCoordinates() {
        let items = APIEndpoint.forecast(lat: 48.85, lon: 2.35).queryItems
        let q = items.first(where: { $0.name == "q" })
        #expect(q?.value == "48.85,2.35")
    }

    @Test("forecast has days=3 query parameter")
    func forecastHasDays3() {
        let items = APIEndpoint.forecast(lat: 0, lon: 0).queryItems
        let days = items.first(where: { $0.name == "days" })
        #expect(days?.value == "3")
    }

    @Test("currentWeather does not have a 'days' parameter")
    func currentWeatherNoDaysParam() {
        let items = APIEndpoint.currentWeather(lat: 0, lon: 0).queryItems
        #expect(!items.contains(where: { $0.name == "days" }))
    }

    @Test("All endpoints include a non-empty API key")
    func allEndpointsHaveAPIKey() {
        let hasKey: (APIEndpoint) -> Bool = { endpoint in
            endpoint.queryItems.contains { $0.name == "key" && !($0.value ?? "").isEmpty }
        }
        #expect(hasKey(.currentWeather(lat: 0, lon: 0)))
        #expect(hasKey(.forecast(lat: 0, lon: 0)))
    }
}
