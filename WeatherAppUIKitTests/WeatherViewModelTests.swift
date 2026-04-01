//
//  WeatherViewModelTests.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Testing
import CoreLocation
@testable import WeatherAppUIKit

@MainActor
@Suite("WeatherViewModel")
struct WeatherViewModelTests {

    // MARK: - State Transitions

    @Test("Initial state is .loading")
    func initialStateIsLoading() {
        let vm = WeatherViewModel(
            locationService: MockLocationService(),
            weatherRepository: MockWeatherRepository()
        )
        guard case .loading = vm.state else {
            Issue.record("Expected .loading, got \(vm.state)"); return
        }
    }

    @Test("State becomes .loaded on successful fetch")
    func stateBecomesLoaded() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        guard case .loaded(let current, _, _) = state else {
            Issue.record("Expected .loaded, got \(state)"); return
        }
        #expect(current.cityName == "Moscow")
    }

    @Test("State becomes .error when repository throws")
    func stateBecomesError() async {
        let repo = MockWeatherRepository()
        repo.currentResult = .failure(NetworkError.noInternetConnection)
        let vm = WeatherViewModel(locationService: MockLocationService(), weatherRepository: repo)
        let state = await awaitNonLoadingState(vm)
        guard case .error = state else {
            Issue.record("Expected .error, got \(state)"); return
        }
    }

    @Test("Error message is non-empty")
    func errorMessageContent() async {
        let repo = MockWeatherRepository()
        repo.currentResult = .failure(NetworkError.noInternetConnection)
        let vm = WeatherViewModel(locationService: MockLocationService(), weatherRepository: repo)
        let state = await awaitNonLoadingState(vm)
        if case .error(let msg) = state {
            #expect(!msg.isEmpty)
        }
    }

    // MARK: - Current Weather Display

    @Test("Temperature formatted as rounded integer with degree sign")
    func temperatureFormatting() async {
        // tempC = 20.5 → rounded = 21 → "21°"
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(let current, _, _) = state {
            #expect(current.temperature == "21°")
        }
    }

    @Test("Feels-like formatted as rounded integer with degree sign")
    func feelsLikeFormatting() async {
        // feelslikeC = 18.0 → "18°"
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(let current, _, _) = state {
            #expect(current.feelsLike == "18°")
        }
    }

    @Test("Humidity formatted with percent sign")
    func humidityFormatting() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(let current, _, _) = state {
            #expect(current.humidity == "60%")
        }
    }

    @Test("HiLo text is non-empty when forecast contains days")
    func hiLoText() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(let current, _, _) = state {
            #expect(!current.hiLoText.isEmpty)
        }
    }

    // MARK: - Hourly Forecast Display

    @Test("First hourly item is labeled 'Now'")
    func hourlyFirstItemIsNow() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, let hourly, _) = state {
            #expect(!hourly.isEmpty)
            #expect(hourly[0].time == L10n.Weather.now)
        }
    }

    @Test("Subsequent hourly items have HH:MM time format")
    func hourlySubsequentItemsTimeFormat() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, let hourly, _) = state, hourly.count > 1 {
            let time = hourly[1].time
            #expect(time.count == 5)
            #expect(time.contains(":"))
        }
    }

    // MARK: - Daily Forecast Display

    @Test("Daily display count matches forecast days")
    func dailyDisplayCount() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, _, let daily) = state {
            #expect(daily.count == 3)
        }
    }

    @Test("Global low is the minimum temperature across all days")
    func dailyGlobalLow() async {
        // day1=10, day2=8, day3=12 → globalLow = 8
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, _, let daily) = state {
            #expect(daily[0].globalLow == 8.0)
        }
    }

    @Test("Global high is the maximum temperature across all days")
    func dailyGlobalHigh() async {
        // day1=25, day2=22, day3=18 → globalHigh = 25
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, _, let daily) = state {
            #expect(daily[0].globalHigh == 25.0)
        }
    }

    @Test("Daily low and high texts contain degree sign")
    func dailyLowHighTexts() async {
        let vm = WeatherViewModel(locationService: MockLocationService(),
                                  weatherRepository: MockWeatherRepository())
        let state = await awaitNonLoadingState(vm)
        if case .loaded(_, _, let daily) = state {
            #expect(daily[0].lowText.contains("°"))
            #expect(daily[0].highText.contains("°"))
        }
    }

    // MARK: - Location Monitoring

    @Test("startMonitoring is called on the location service after first fetch")
    func startMonitoringCalled() async {
        let locationService = MockLocationService()
        let vm = WeatherViewModel(locationService: locationService,
                                  weatherRepository: MockWeatherRepository())
        _ = await awaitNonLoadingState(vm)
        #expect(locationService.startMonitoringCalled)
    }

    @Test("Location update triggers a new fetch")
    func locationUpdateTriggersFetch() async {
        let locationService = MockLocationService()
        let repo = MockWeatherRepository()
        let vm = WeatherViewModel(locationService: locationService, weatherRepository: repo)
        _ = await awaitNonLoadingState(vm)
        let callsBefore = repo.fetchCurrentCallCount

        locationService.onLocationUpdated?(CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522))
        await yield()

        #expect(repo.fetchCurrentCallCount > callsBefore)
    }

    @Test("Location update passes the new coordinate to the repository")
    func locationUpdateUsesNewCoordinate() async {
        let locationService = MockLocationService()
        let repo = MockWeatherRepository()
        let vm = WeatherViewModel(locationService: locationService, weatherRepository: repo)
        _ = await awaitNonLoadingState(vm)

        let paris = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        locationService.onLocationUpdated?(paris)
        await yield()

        #expect(repo.lastLat == paris.latitude)
        #expect(repo.lastLon == paris.longitude)
    }

    // MARK: - Retry

    @Test("Retry triggers another fetch")
    func retryTriggersFetch() async {
        let repo = MockWeatherRepository()
        let vm = WeatherViewModel(locationService: MockLocationService(), weatherRepository: repo)
        _ = await awaitNonLoadingState(vm)
        let callsBefore = repo.fetchCurrentCallCount

        vm.retry()
        await yield()

        #expect(repo.fetchCurrentCallCount > callsBefore)
    }

    @Test("Retry uses the last known coordinate")
    func retryUsesLastCoordinate() async {
        let coord = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        let repo = MockWeatherRepository()
        let vm = WeatherViewModel(locationService: MockLocationService(location: coord),
                                  weatherRepository: repo)
        _ = await awaitNonLoadingState(vm)

        vm.retry()
        await yield()

        #expect(repo.lastLat == coord.latitude)
        #expect(repo.lastLon == coord.longitude)
    }
}
