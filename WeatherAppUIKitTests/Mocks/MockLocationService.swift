//
//  MockLocationService.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import CoreLocation
@testable import WeatherAppUIKit

final class MockLocationService: LocationServiceProtocol {

    var defaultLocation = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
    var stopMonitoringCalled = false
    var requestLocationCalled = false

    private let locationToReturn: CLLocationCoordinate2D
    private(set) var capturedOnUpdate: ((CLLocationCoordinate2D) -> Void)?

    init(location: CLLocationCoordinate2D = MockData.coordinate) {
        locationToReturn = location
    }

    func requestLocation(onUpdate: @escaping (CLLocationCoordinate2D) -> Void) {
        requestLocationCalled = true
        capturedOnUpdate = onUpdate
        onUpdate(locationToReturn)
    }

    func stopMonitoring() {
        stopMonitoringCalled = true
    }

    func simulateLocationUpdate(_ coordinate: CLLocationCoordinate2D) {
        capturedOnUpdate?(coordinate)
    }
}
