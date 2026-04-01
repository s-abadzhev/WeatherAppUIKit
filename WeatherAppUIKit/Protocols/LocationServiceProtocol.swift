//
//  LocationServiceProtocol.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    func requestLocation(onUpdate: @escaping (CLLocationCoordinate2D) -> Void)
    func stopMonitoring()
    var defaultLocation: CLLocationCoordinate2D { get }
}
