//
//  LocationServiceProtocol.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    var onLocationUpdated: ((CLLocationCoordinate2D) -> Void)? { get set }
    func requestLocation() async -> CLLocationCoordinate2D
    func startMonitoring()
    func stopMonitoring()
    var defaultLocation: CLLocationCoordinate2D { get }
}
