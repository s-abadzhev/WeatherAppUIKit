//
//  MockLocationService.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import CoreLocation
@testable import WeatherAppUIKit

final class MockLocationService: LocationServiceProtocol {
    var onLocationUpdated: ((CLLocationCoordinate2D) -> Void)?
    var defaultLocation = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
    var startMonitoringCalled = false
    var stopMonitoringCalled  = false

    private let locationToReturn: CLLocationCoordinate2D

    init(location: CLLocationCoordinate2D = MockData.coordinate) {
        locationToReturn = location
    }

    func requestLocation() async -> CLLocationCoordinate2D { locationToReturn }
    func startMonitoring() { startMonitoringCalled = true }
    func stopMonitoring()  { stopMonitoringCalled  = true }
}
