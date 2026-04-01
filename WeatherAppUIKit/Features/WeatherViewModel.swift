//
//  WeatherViewModel.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation
import CoreLocation

struct CurrentWeatherDisplay {
    let cityName: String
    let temperature: String
    let conditionText: String
    let hiLoText: String
    let feelsLike: String
    let humidity: String
    let wind: String
}

struct HourlyItemDisplay {
    let time: String
    let conditionCode: Int
    let temperature: String
}

struct DailyItemDisplay {
    let dayName: String
    let conditionCode: Int
    let low: Double
    let high: Double
    let lowText: String
    let highText: String
    let globalLow: Double
    let globalHigh: Double
}

enum WeatherViewState {
    case loading
    case loaded(
        current: CurrentWeatherDisplay,
        hourly: [HourlyItemDisplay],
        daily: [DailyItemDisplay]
    )
    case error(String)
}

private struct TimeoutError: Error {}

@MainActor
final class WeatherViewModel {

    var onStateChanged: ((WeatherViewState) -> Void)?

    private(set) var state: WeatherViewState = .loading {
        didSet { onStateChanged?(state) }
    }

    private let locationService: LocationServiceProtocol
    private let weatherRepository: WeatherRepositoryProtocol

    private var lastCoordinate: CLLocationCoordinate2D?
    private static let totalTimeout: TimeInterval = 20

    init(locationService: LocationServiceProtocol,
         weatherRepository: WeatherRepositoryProtocol) {
        self.locationService = locationService
        self.weatherRepository = weatherRepository
        setupLocationMonitoring()
    }

    private func setupLocationMonitoring() {
        Task {
            let coordinate = await locationService.requestLocation()
            self.lastCoordinate = coordinate
            self.fetchWeather(for: coordinate)
            locationService.startMonitoring()
            locationService.onLocationUpdated = { [weak self] coordinate in
                self?.fetchWeather(for: coordinate)
                self?.lastCoordinate = coordinate
            }
        }
    }

    func retry() {
        fetchWeather(for: lastCoordinate ?? locationService.defaultLocation)
    }

    private func fetchWeather(for coordinate: CLLocationCoordinate2D) {
        if case .error = state { state = .loading }

        Task {
            do {
                let (current, forecast) = try await withTimeout(seconds: Self.totalTimeout) {
                    async let currentTask = self.weatherRepository.fetchCurrent(
                        lat: coordinate.latitude,
                        lon: coordinate.longitude
                    )
                    async let forecastTask = self.weatherRepository.fetchForecast(
                        lat: coordinate.latitude,
                        lon: coordinate.longitude
                    )
                    return try await (currentTask, forecastTask)
                }
                let display = buildCurrentDisplay(from: current, forecast: forecast)
                let hourly = buildHourlyDisplay(from: forecast)
                let daily = buildDailyDisplay(from: forecast)
                state = .loaded(current: display, hourly: hourly, daily: daily)
            } catch is TimeoutError {
                state = .error(WeatherError.timeout.localizedDescription)
            } catch let urlError as URLError where urlError.code == .timedOut {
                state = .error(WeatherError.timeout.localizedDescription)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    private func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            guard let result = try await group.next() else { throw TimeoutError() }
            group.cancelAll()
            return result
        }
    }

    private func buildCurrentDisplay(from current: CurrentResponse, forecast: ForecastResponse) -> CurrentWeatherDisplay {
        let hiLoText: String
        if let today = forecast.forecast.forecastday.first {
            hiLoText = L10n.Weather.hiLo(hi: Int(today.day.maxtempC.rounded()), lo: Int(today.day.mintempC.rounded()))
        } else {
            hiLoText = ""
        }
        return CurrentWeatherDisplay(
            cityName: current.location.name,
            temperature: "\(Int(current.current.tempC.rounded()))°",
            conditionText: current.current.condition.text,
            hiLoText: hiLoText,
            feelsLike: "\(Int(current.current.feelslikeC.rounded()))°",
            humidity: "\(current.current.humidity)%",
            wind: L10n.Weather.windSpeed(Int(current.current.windKph.rounded()))
        )
    }

    private func buildHourlyDisplay(from forecast: ForecastResponse) -> [HourlyItemDisplay] {
        var items: [HourlyItemDisplay] = []
        let currentHour = Calendar.current.component(.hour, from: Date())

        if let today = forecast.forecast.forecastday.first {
            let remaining = today.hour.filter { hourItem in
                guard let hourStr = hourItem.time.split(separator: " ").last,
                      let h = Int(hourStr.prefix(2)) else { return false }
                return h >= currentHour
            }
            items.append(contentsOf: remaining.enumerated().map { index, hour in
                HourlyItemDisplay(
                    time: index == 0 ? L10n.Weather.now : formatHourTime(hour.time),
                    conditionCode: hour.condition.code,
                    temperature: "\(Int(hour.tempC.rounded()))°"
                )
            })
        }

        if forecast.forecast.forecastday.count > 1 {
            items.append(contentsOf: forecast.forecast.forecastday[1].hour.map { hour in
                HourlyItemDisplay(
                    time: formatHourTime(hour.time),
                    conditionCode: hour.condition.code,
                    temperature: "\(Int(hour.tempC.rounded()))°"
                )
            })
        }

        return items
    }

    private func buildDailyDisplay(from forecast: ForecastResponse) -> [DailyItemDisplay] {
        let days = forecast.forecast.forecastday
        let globalLow = days.map(\.day.mintempC).min() ?? 0
        let globalHigh = days.map(\.day.maxtempC).max() ?? 0

        return days.enumerated().map { index, forecastDay in
            DailyItemDisplay(
                dayName: formatDayName(forecastDay.date),
                conditionCode: forecastDay.day.condition.code,
                low: forecastDay.day.mintempC,
                high: forecastDay.day.maxtempC,
                lowText: "\(Int(forecastDay.day.mintempC.rounded()))°",
                highText: "\(Int(forecastDay.day.maxtempC.rounded()))°",
                globalLow: globalLow,
                globalHigh: globalHigh
            )
        }
    }

    private func formatHourTime(_ time: String) -> String {
        let parts = time.split(separator: " ")
        return parts.count > 1 ? String(parts[1].prefix(5)) : time
    }

    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let dayNameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "EE"
        return f
    }()

    private func formatDayName(_ dateString: String) -> String {
        guard let date = Self.dateParser.date(from: dateString) else { return dateString }
        return Self.dayNameFormatter.string(from: date).capitalized
    }
}
