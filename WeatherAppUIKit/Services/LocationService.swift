//
//  LocationService.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    private var isMonitoring = false
    private var timeoutWork: DispatchWorkItem?

    var onLocationUpdated: ((CLLocationCoordinate2D) -> Void)?

    var defaultLocation = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
    private static let locationTimeout: TimeInterval = 10

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500
    }

    func requestLocation() async -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                self.startTimeout()
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            return await fetchCurrentLocation()
        default:
            return defaultLocation
        }
    }

    func startMonitoring() {
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

    private func fetchCurrentLocation() async -> CLLocationCoordinate2D {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.startTimeout()
            self.locationManager.requestLocation()
        }
    }

    // MARK: - Timeout

    private func startTimeout() {
        timeoutWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.resumeWithFallback()
        }
        timeoutWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.locationTimeout, execute: work)
    }

    private func cancelTimeout() {
        timeoutWork?.cancel()
        timeoutWork = nil
    }

    private func resumeWithFallback() {
        guard let continuation else { return }
        self.continuation = nil
        cancelTimeout()
        continuation.resume(returning: defaultLocation)
    }

    private func resumeWith(_ coordinate: CLLocationCoordinate2D) {
        guard let continuation else { return }
        self.continuation = nil
        cancelTimeout()
        continuation.resume(returning: coordinate)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            if continuation != nil {
                resumeWithFallback()
            }
            return
        }
        if continuation != nil {
            resumeWith(location.coordinate)
        } else if isMonitoring {
            onLocationUpdated?(location.coordinate)
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard continuation != nil else { return }
        resumeWithFallback()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            resumeWithFallback()
        default:
            break
        }
    }
}
