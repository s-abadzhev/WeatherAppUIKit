//
//  NetworkClient.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

protocol NetworkClient: Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

