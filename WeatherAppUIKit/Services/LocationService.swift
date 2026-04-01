//
//  LocationService.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var isMonitoring = false
    private var hasReceivedLocation = false

    var onLocationUpdated: ((CLLocationCoordinate2D) -> Void)?

    var defaultLocation = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 1000
    }

    func requestLocation(onUpdate: @escaping (CLLocationCoordinate2D) -> Void) {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            onLocationUpdated = onUpdate
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            onLocationUpdated = onUpdate
            startMonitoring()
        default:
            onUpdate(defaultLocation)
        }
    }

    private func startMonitoring() {
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        guard !isMonitoring else { return }
        isMonitoring = true
        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        isMonitoring = false
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        hasReceivedLocation = true
        onLocationUpdated?(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !hasReceivedLocation else { return }
        onLocationUpdated?(defaultLocation)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startMonitoring()
        case .denied, .restricted:
            onLocationUpdated?(defaultLocation)
        default:
            break
        }
    }
}
